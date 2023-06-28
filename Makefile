.PHONY: test

export WORKLOAD
export ENVIRONMENT
export USECASE

#test_extended:

test:
	cd tests && go test -v -timeout 60m -run TestApplyNoError/$(USECASE) ./aks_test.go

#test_local:

